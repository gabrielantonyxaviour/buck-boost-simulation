/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_VAULT_CONTRACT_ID: string
  readonly VITE_TOKEN_CONTRACT_ID: string
}

interface ImportMeta {
  readonly env: ImportMetaEnv
}
