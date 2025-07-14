FROM ubuntu:22.04

# Instalar dependencias
RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y \
     git \
     maven \
     openjdk-11-jre-headless \
     postgresql-client \
     apache2 \
     curl \
     wget \
     unzip \
     apt-transport-https \
     ca-certificates \
     gnupg \
     dirmngr \
  # VS Code
  && curl -sSL https://packages.microsoft.com/keys/microsoft.asc \
       | gpg --dearmor > /usr/share/keyrings/microsoft.gpg \
  && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
       > /etc/apt/sources.list.d/vscode.list \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y code \
  # .NET SDK
  && curl -sSL https://dot.net/v1/dotnet-install.sh -o dotnet-install.sh \
  && bash dotnet-install.sh --channel LTS \
  && rm dotnet-install.sh \
  # AWS CLI v2
  && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
  && unzip awscliv2.zip \
  && ./aws/install \
  && rm -rf awscliv2.zip aws \
  # Limpiar caches de apt
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Hacer dotnet y code accesibles sin rutas ni flags adicionales
ENV DOTNET_ROOT=/root/.dotnet
ENV PATH="$PATH:/root/.dotnet"

# Configurar Apache "Hola Mundo"
COPY index.html /var/www/html/index.html

EXPOSE 80
CMD ["apache2ctl", "-D", "FOREGROUND"]