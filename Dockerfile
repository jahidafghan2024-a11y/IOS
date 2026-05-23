FROM node:20-bullseye-slim

RUN apt-get update && apt-get install -y \
    git make g++ cmake \
    libssl-dev libzip-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --recurse-submodules https://github.com/zhlynn/zsign.git /tmp/zsign \
    && cd /tmp/zsign \
    && cmake -DCMAKE_BUILD_TYPE=Release . \
    && make -j$(nproc) \
    && cp zsign /usr/local/bin/zsign \
    && chmod +x /usr/local/bin/zsign \
    && rm -rf /tmp/zsign

RUN npm install -g pnpm

WORKDIR /app

COPY package.json pnpm-lock.yaml* ./

RUN mkdir -p patches && pnpm install --no-frozen-lockfile

COPY . .

RUN pnpm run build

EXPOSE 3000
ENV NODE_ENV=production
CMD ["pnpm", "start"]
