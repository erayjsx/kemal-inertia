# Kemal + Inertia + Svelte Example

This is an example application demonstrating how to use Kemal with Inertia.js and Svelte.

## Prerequisites

- [Crystal](https://crystal-lang.org/install/)
- [Node.js](https://nodejs.org/)

## Setup

1. Install Crystal dependencies:
   ```bash
   shards install
   ```

2. Install Node.js dependencies:
   ```bash
   npm install
   ```

## Running the Application

You need to run both the Kemal server (backend) and the Vite server (frontend) simultaneously.

1. **Terminal 1:** Start the Vite development server
   ```bash
   npm run dev
   ```

2. **Terminal 2:** Start the Kemal server
   ```bash
   crystal run src/app.cr
   ```

3. Open your browser and visit [http://localhost:3000](http://localhost:3000)

## Building for Production

1. Build the frontend assets:
   ```bash
   npm run build
   ```

2. Build the Kemal application:
   ```bash
   crystal build src/app.cr --release
   ```

3. Run the application in production mode:
   ```bash
   KEMAL_ENV=production ./app
   ```
   
   Or if running with `crystal run`:
   ```bash
   KEMAL_ENV=production crystal run src/app.cr
   ```

## Troubleshooting

### Connection Refused (Port 5173)

If you see errors like `GET http://localhost:5173/@vite/client net::ERR_CONNECTION_REFUSED`, it means the application is trying to connect to the Vite development server but cannot find it.

- **In Development:** Ensure `npm run dev` is running in a separate terminal.
- **In Production:** Ensure you have built the assets (`npm run build`) and are running the Kemal app with `KEMAL_ENV=production`.
