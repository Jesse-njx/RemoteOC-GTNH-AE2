# Security policy

Please report security issues privately through GitHub's **Report a vulnerability**
feature for this repository. Do not include live server tokens, private URLs, or
other credentials in a public issue.

Before deployment, copy `server/.env.example` to `server/.env` and replace the
placeholder with a unique, long random token. Never commit that file; `.env` files
are ignored by Git.
