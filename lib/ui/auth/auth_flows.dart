/// How an auth flow ended. [unverified] means an email account exists but its
/// address is not verified yet (cloud presets and Premium stay off).
enum AuthOutcome { none, unverified, verified }
