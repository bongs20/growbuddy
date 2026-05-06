const admin = require("firebase-admin");
const fetch = require("node-fetch");
const fs = require("fs");
const path = require("path");

// === CONFIG ===
loadEnvFile(path.join(__dirname, ".env"));

const serviceAccount = loadServiceAccount();
const API_KEY = process.env.FIREBASE_WEB_API_KEY;
const DEVICE_UID = process.env.DEVICE_UID || "device_001"; // bebas, tapi harus konsisten di ESP32

if (!API_KEY) {
  throw new Error("FIREBASE_WEB_API_KEY belum diisi.");
}

// Init Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

function loadEnvFile(filePath) {
  if (!fs.existsSync(filePath)) {
    return;
  }

  const content = fs.readFileSync(filePath, "utf8");
  for (const rawLine of content.split(/\r?\n/)) {
    const line = rawLine.trim();
    if (!line || line.startsWith("#")) {
      continue;
    }

    const separatorIndex = line.indexOf("=");
    if (separatorIndex === -1) {
      continue;
    }

    const key = line.slice(0, separatorIndex).trim();
    let value = line.slice(separatorIndex + 1).trim();

    if (
      (value.startsWith('"') && value.endsWith('"')) ||
      (value.startsWith("'") && value.endsWith("'"))
    ) {
      value = value.slice(1, -1);
    }

    if (!(key in process.env)) {
      process.env[key] = value;
    }
  }
}

function loadServiceAccount() {
  const envServiceAccount = {
    type: process.env.FIREBASE_ADMIN_TYPE || "service_account",
    project_id: process.env.FIREBASE_ADMIN_PROJECT_ID,
    private_key_id: process.env.FIREBASE_ADMIN_PRIVATE_KEY_ID,
    private_key: process.env.FIREBASE_ADMIN_PRIVATE_KEY
      ? process.env.FIREBASE_ADMIN_PRIVATE_KEY.replace(/\\n/g, "\n")
      : undefined,
    client_email: process.env.FIREBASE_ADMIN_CLIENT_EMAIL,
    client_id: process.env.FIREBASE_ADMIN_CLIENT_ID,
    auth_uri: process.env.FIREBASE_ADMIN_AUTH_URI || "https://accounts.google.com/o/oauth2/auth",
    token_uri: process.env.FIREBASE_ADMIN_TOKEN_URI || "https://oauth2.googleapis.com/token",
    auth_provider_x509_cert_url:
      process.env.FIREBASE_ADMIN_AUTH_PROVIDER_X509_CERT_URL ||
      "https://www.googleapis.com/oauth2/v1/certs",
    client_x509_cert_url: process.env.FIREBASE_ADMIN_CLIENT_X509_CERT_URL,
    universe_domain: process.env.FIREBASE_ADMIN_UNIVERSE_DOMAIN || "googleapis.com",
  };

  const hasEnvCredentials =
    envServiceAccount.project_id &&
    envServiceAccount.private_key &&
    envServiceAccount.client_email;

  if (hasEnvCredentials) {
    return envServiceAccount;
  }

  throw new Error(
    "Firebase Admin credential tidak ditemukan. Isi json/.env sesuai template json/serviceAccount.json."
  );
}

// Step 1: buat custom token
async function createCustomToken() {
  const token = await admin.auth().createCustomToken(DEVICE_UID);
  return token;
}

// Step 2: tukar ke ID token (yang dipakai ESP32)
async function exchangeForIdToken(customToken) {
  const url = `https://identitytoolkit.googleapis.com/v1/accounts:signInWithCustomToken?key=${API_KEY}`;

  const res = await fetch(url, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      token: customToken,
      returnSecureToken: true,
    }),
  });

  const data = await res.json();
  return data;
}

// MAIN
(async () => {
  try {
    const customToken = await createCustomToken();
    console.log("Custom Token:", customToken);

    const result = await exchangeForIdToken(customToken);

    console.log("\n=== HASIL ===");
    console.log("ID Token:", result.idToken);
    console.log("Refresh Token:", result.refreshToken);
    console.log("Expires In:", result.expiresIn, "detik");
  } catch (err) {
    console.error(err);
  }
})();
