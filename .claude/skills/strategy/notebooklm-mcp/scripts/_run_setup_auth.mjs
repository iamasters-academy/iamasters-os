import { AuthManager } from "file:///C:/Users/Pau/AppData/Local/npm-cache/_npx/0d29dd9f4e472da9/node_modules/notebooklm-mcp/dist/auth/auth-manager.js";

const auth = new AuthManager();
console.log("Abriendo navegador para login manual de Google en NotebookLM...");
const ok = await auth.performSetup(async (msg, cur, total) => {
  console.log(`[${cur}/${total}] ${msg}`);
});
console.log(ok ? "✅ Autenticación guardada correctamente." : "❌ Falló o se canceló la autenticación.");
process.exit(ok ? 0 : 1);
