# Pi Dashboard Solutions Research Report

*Research for Raspberry Pi 5 Home Server (8GB RAM)*

---

## Executive Summary

Based on extensive research, I've identified **4 excellent open-source dashboard solutions** suitable for a Raspberry Pi 5 home server. Each offers different trade-offs between features, resource usage, and ease of setup.

**Top Recommendation: Homepage** — Best balance of features, Pi-friendliness, and ease of Docker deployment.

---

## 1. Homepage

| Attribute | Details |
|-----------|---------|
| **GitHub Repo** | https://github.com/gethomepage/homepage |
| **Stars** | ~20,000+ |
| **License** | GPL-3.0 |
| **Tech Stack** | Node.js, React, Next.js |
| **Docker** | ✅ Yes (official image) |

### Key Features
- **Service Widgets**: 100+ built-in integrations (Plex, Sonarr, Radarr, qBittorrent, etc.)
- **System Monitoring**: CPU, memory, disk, network via custom widgets
- **Status Checks**: HTTP/ping monitoring for service health
- **Weather/Calendar**: Built-in info widgets
- **Custom CSS**: Full theming support
- **Multi-language**: i18n support
- **Search**: Multiple search providers
- **Bookmarks**: Quick access links

### Pros
- ✅ Extremely lightweight (~100MB RAM idle)
- ✅ Native Docker support with easy config via YAML
- ✅ Huge ecosystem of pre-built widgets
- ✅ Beautiful, modern UI out of the box
- ✅ Very active community and development
- ✅ Excellent documentation
- ✅ Works perfectly on Pi 4/5

### Cons
- ❌ Configuration via YAML files (no GUI editor)
- ❌ No built-in user authentication (use reverse proxy)
- ❌ Limited Pi-specific stats (temp, GPIO) without custom widgets

### Docker Setup (Pi-Optimized)
```yaml
services:
  homepage:
    image: ghcr.io/gethomepage/homepage:latest
    container_name: homepage
    ports:
      - "3000:3000"
    volumes:
      - ./config:/app/config
      - /var/run/docker.sock:/var/run/docker.sock:ro
    environment:
      - HOMEPAGE_VAR_OPENWEATHERMAP_API_KEY=${OPENWEATHERMAP_API_KEY}
    restart: unless-stopped
```

---

## 2. Glance

| Attribute | Details |
|-----------|---------|
| **GitHub Repo** | https://github.com/glanceapp/glance |
| **Stars** | 32,347 |
| **License** | AGPL-3.0 |
| **Tech Stack** | Go |
| **Docker** | ✅ Yes (single binary/image) |

### Key Features
- **RSS/Feeds**: Multiple feed aggregators with filtering
- **System Stats**: CPU, memory, disk, network widgets
- **Weather**: OpenWeatherMap integration
- **Calendar**: ICS calendar support
- **Stocks/Crypto**: Market tracking
- **Server Monitoring**: UptimeKuma, Healthchecks integration
- **YouTube/Twitch**: Channel stats and live indicators
- **Reddit/HackerNews**: Subreddit and story widgets

### Pros
- ✅ **Written in Go** — extremely fast, minimal resource usage
- ✅ Single binary deployment (no dependencies)
- ✅ Built-in Pi temp monitoring support
- ✅ Modern, clean UI
- ✅ YAML configuration (clean and versionable)
- ✅ Very active development
- ✅ Lowest memory footprint of all options (~50MB)

### Cons
- ❌ Fewer service integrations than Homepage
- ❌ No GUI configuration editor
- ❌ Newer project (less battle-tested)
- ❌ Focused more on "feeds" than service management

### Docker Setup
```yaml
services:
  glance:
    image: glanceapp/glance:latest
    container_name: glance
    ports:
      - "8080:8080"
    volumes:
      - ./config:/app/config
      - /var/run/docker.sock:/var/run/docker.sock:ro
    restart: unless-stopped
```

---

## 3. Dashy

| Attribute | Details |
|-----------|---------|
| **GitHub Repo** | https://github.com/Lissy93/dashy |
| **Stars** | 24,134 |
| **License** | MIT |
| **Tech Stack** | Vue.js, Node.js |
| **Docker** | ✅ Yes |

### Key Features
- **Visual Editor**: Drag-and-drop UI configuration
- **Status Indicators**: Health checks for all services
- **Theming**: 20+ built-in themes + custom CSS
- **Widgets**: Weather, crypto, clock, weather, GitHub stats
- **Search**: Global search across services
- **Authentication**: Built-in auth (basic, OIDC)
- **Multi-page**: Organize services across pages
- **Icons**: Built-in icon search and upload
- **Workspaces**: Multiple dashboards per instance

### Pros
- ✅ **GUI configuration editor** — no YAML editing needed
- ✅ Built-in authentication options
- ✅ Most themable/customizable option
- ✅ Built-in status monitoring
- ✅ Large widget library
- ✅ Very polished UI
- ✅ Good documentation

### Cons
- ❌ Higher resource usage (~300-400MB RAM)
- ❌ Slower startup on Pi (Node.js build process)
- ❌ Heavier than Homepage/Glance for a Pi
- ❌ Some features require more complex setup

### Docker Setup
```yaml
services:
  dashy:
    image: lissy93/dashy:latest
    container_name: dashy
    ports:
      - "4000:80"
    volumes:
      - ./conf.yml:/app/public/conf.yml
    environment:
      - NODE_ENV=production
    restart: unless-stopped
    # Consider adding memory limits for Pi
    deploy:
      resources:
        limits:
          memory: 512M
```

---

## 4. Heimdall

| Attribute | Details |
|-----------|---------|
| **GitHub Repo** | https://github.com/linuxserver/Heimdall |
| **Stars** | 9,032 |
| **License** | MIT |
| **Tech Stack** | PHP, Laravel |
| **Docker** | ✅ Yes (LinuxServer.io image) |

### Key Features
- **Enhanced Apps**: 200+ applications with API integrations
- **Foundation Apps**: Custom search/bar for each service
- **Tags**: Organize apps by category
- **Backgrounds**: Custom wallpapers
- **Multi-user**: User accounts
- **Statistics**: Some apps show live stats

### Pros
- ✅ **Longest track record** (mature, stable)
- ✅ Huge library of "enhanced" apps
- ✅ Simple, clean interface
- ✅ LinuxServer.io Docker image (well maintained)
- ✅ Low resource usage (~150MB RAM)
- ✅ Easy backup/restore

### Cons
- ❌ PHP-based (heavier than Go alternatives)
- ❌ UI looks dated compared to newer options
- ❌ Less active development recently
- ❌ Limited system monitoring widgets
- ❌ Configuration less flexible

### Docker Setup
```yaml
services:
  heimdall:
    image: lscr.io/linuxserver/heimdall:latest
    container_name: heimdall
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Asia/Shanghai
    volumes:
      - ./config:/config
    ports:
      - "80:80"
      - "443:443"
    restart: unless-stopped
```

---

## Comparison Matrix

| Feature | Homepage | Glance | Dashy | Heimdall |
|---------|----------|--------|-------|----------|
| **Memory Usage** | ~100MB | ~50MB | ~400MB | ~150MB |
| **CPU Usage** | Low | Very Low | Medium | Low |
| **Docker Setup** | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| **Pi Temp/GPIO** | Via widget | Built-in | Limited | No |
| **GUI Editor** | ❌ | ❌ | ✅ | ✅ |
| **Widget Library** | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| **Status Monitoring** | ✅ | ✅ | ✅ | Limited |
| **Authentication** | ❌ (use proxy) | ❌ | ✅ | ✅ |
| **Active Dev** | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐ |
| **Pi 5 Suitability** | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ |

---

## Final Recommendation

### 🏆 Best Overall: **Homepage**

For a Raspberry Pi 5 home server, **Homepage** is the recommended choice because:

1. **Optimal Resource Usage**: ~100MB RAM leaves plenty of headroom for other services on your 8GB Pi
2. **Docker-Native**: Simple, single-container deployment
3. **Widget Ecosystem**: Unmatched library of 100+ service integrations
4. **Active Development**: Constant updates and new widgets
5. **Pi Proven**: Widely used by the homelab community on Raspberry Pi hardware
6. **Clean Aesthetic**: Modern, professional-looking dashboard

### 🥈 Runner-Up: **Glance**

Choose Glance if you want:
- Absolute minimal resource usage (Go binary)
- Built-in Pi temperature monitoring
- Feed/news aggregation focus
- Ultra-fast load times

### When to Choose Others:
- **Dashy**: If you prioritize GUI configuration and don't mind higher resource usage
- **Heimdall**: If you want the most mature solution with 200+ enhanced apps

---

## Quick Start Command

```bash
# Create directory
mkdir -p ~/homepage/config && cd ~/homepage

# Download sample config
curl -o config/settings.yaml https://raw.githubusercontent.com/gethomepage/homepage/main/config/settings.yaml
curl -o config/widgets.yaml https://raw.githubusercontent.com/gethomepage/homepage/main/config/widgets.yaml
curl -o config/services.yaml https://raw.githubusercontent.com/gethomepage/homepage/main/config/services.yaml

# Start with Docker
docker run -d \
  --name homepage \
  -p 3000:3000 \
  -v $(pwd)/config:/app/config \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  --restart unless-stopped \
  ghcr.io/gethomepage/homepage:latest

# Access at http://pi-ip:3000
```

---

*Report generated: 2026-03-04*
