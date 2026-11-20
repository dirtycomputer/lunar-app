import { defineConfig } from 'vite'
import plugin from '@dcloudio/vite-plugin-uni'

const uni = plugin.default || plugin
export default defineConfig({ plugins: [uni()], server: { port: 5199, strictPort: true } })
