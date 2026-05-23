FROM node:20-bullseye-slim

RUN apt-get update && apt-get install -y \
    git cmake build-essential \
    libssl-dev libzip-dev \
    ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 https://github.com/zhlynn/zsign.git /tmp/zsign \
    && cd /tmp/zsign \
    && cmake -DCMAKE_BUILD_TYPE=Release . \
    && make -j$(nproc) \
    && cp zsign /usr/local/bin/zsign \
    && chmod +x /usr/local/bin/zsign \
    && rm -rf /tmp/zsign \
    && zsign 2>&1 | head -1 || true

RUN npm install -g pnpm

WORKDIR /app

COPY package.json ./
COPY pnpm-lock.yaml* ./

RUN pnpm install --frozen-lockfile || pnpm install

COPY . .

RUN pnpm run build

EXPOSE 3000
ENV NODE_ENV=production
CMD ["pnpm", "start"]
