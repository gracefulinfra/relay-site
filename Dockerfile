# syntax=docker/dockerfile:1@sha256:4edf897a3ffa55b89f906fc8cc78afdb3f1834cc9c7083565e611a8a7d5fe99e
# Bootstrap smoke image (P0-01). Base images are pinned by digest; Renovate keeps them current.
FROM --platform=$BUILDPLATFORM node:24.22.2-trixie-slim@sha256:0820eaa85e07d0490446dd01d14707e17e6108a36988cf374899cd057eb3812d AS build
WORKDIR /src
RUN corepack enable
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile
COPY . .
RUN pnpm build

FROM gcr.io/distroless/nodejs24-debian13:nonroot@sha256:088a01637f22908632ba09018be2e0b516f2fa6f7869c191d29491139db43c78
ARG VERSION=dev COMMIT=unknown
ENV RELAY_VERSION=$VERSION RELAY_COMMIT=$COMMIT NODE_ENV=production
WORKDIR /app
COPY --from=build /src/dist/ ./
USER nonroot:nonroot
CMD ["smoke.js"]
