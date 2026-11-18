# syntax=docker/dockerfile:1@sha256:4edf897a3ffa55b89f906fc8cc78afdb3f1834cc9c7083565e611a8a7d5fe99e
# Bootstrap smoke image (P0-01). Base images are pinned by digest; Renovate keeps them current.
FROM --platform=$BUILDPLATFORM node:24.22.3-trixie-slim@sha256:af02d57b57719b9657a45199a79264a9437940cd55b3c7b3fc99615654f124a0 AS build
WORKDIR /src
RUN corepack enable
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile
COPY . .
RUN pnpm build

FROM gcr.io/distroless/nodejs24-debian13:nonroot@sha256:6abfcb367ebc291572c774c1592a986be2ab26a2486f73093401327495a5962a
ARG VERSION=dev COMMIT=unknown
ENV RELAY_VERSION=$VERSION RELAY_COMMIT=$COMMIT NODE_ENV=production
WORKDIR /app
COPY --from=build /src/dist/ ./
USER nonroot:nonroot
CMD ["smoke.js"]
