# Sentience Hub

Sentience Hub is a decentralized platform for TTRPG character management and in-game economy. It integrates Identity Forge via the Identity Bridge smart contract so that a character’s identity—once forged—is used as the single source of truth for login and profile management in the Hub.

## Features

- **Character Creation:** Roll attributes, core traits, and personality profiles; assign heritage and journey.
- **Identity Integration:** Use a blockchain-backed identity (via Identity Bridge) as login credentials.
- **Wallet & Economy:** Manage in-game currencies including $FUDDY, ig‑FUDDY, Crystals, and NFTs.
- **Resolution Mechanics:** Harmonized Hex & Die system integrated with Fate Point spending and Telegram messaging.
- **Smart Contract Interactions:** Full backend integration via DFINITY canisters.

## File Structure

The repository includes all smart contract code (Motoko), a React front end with supporting API layers, declarations for canister interfaces, and deployment workflows via GitHub Actions.

## Setup

1. Clone this repository.
2. Install dependencies with `npm install`.
3. Deploy canisters using the provided GitHub Actions workflow.
4. Run the development server with `npm start`.

## License

MIT License
