# Custom Kong Plugin: JWT Authentication via Header or Cookie from Extend Service

## Overview

This repository contains a custom plugin for [Kong Gateway](https://konghq.com/kong/) that authenticates incoming requests using a JSON Web Token (JWT) from either the request header or cookie. The plugin validates the JWT and ensures the request is authenticated before allowing access to the upstream services.

### Features

- Authentication via JWT in the request header or cookies
- Configurable token location (header or cookie)
