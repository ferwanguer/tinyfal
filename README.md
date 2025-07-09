# tinyfal

**Tinyfal** is a modern, hassle free, mobile-first server monitoring platform focused on simplicity, security, and privacy. It uses lightweight **Telegraf** agents configured with HTTP output plugins to push encrypted system metrics to a secure backend, where they can be accessed from an elegant Flutter mobile app.

Built for homelabbers, developers, and small enterprise teams, tinyfal focuses on ease of use, mobile accessibility, and security without compromising control. You will have it deployed in just a few minutes.

---

## Features

- ✅ **Telegraf Integration** – Use a proven agent with minimal overhead and customizable inputs.
- ✅ **No Open Ports or SSH Needed** – Servers push data via HTTP; your infrastructure stays closed to external access.
- ✅ **Per-Server Auth Tokens** – Each server uses a unique token for validation and access control.
- ✅ **Secure & Private** – Data encrypted in transit. Optional E2EE support to prevent admin-side inspection.
- ✅ **Mobile Dashboard** – Built in Flutter for Android and iOS to give you real-time insights anywhere.
- ✅ **Firebase Backend** – Cloud Functions validate, process, and store metrics with scalability and reliability.
- 🔔 **Custom Alerts (Premium)** – Define resource thresholds and receive mobile push notifications.

## 🏠 Self-Hosting Support

Currently, **Tinyfal** is available only as a cloud-based solution using Firebase Functions and Firestore.

We plan to introduce a **self-hosted (on-premise) version** once the platform reaches a stable and mature release. This future version will allow full control over data storage and backend infrastructure. **That said, all source code — including the backend — is fully open source.** You are free to audit, modify, or adapt it to your own infrastructure at any time.

Stay tuned for updates as development progresses.






