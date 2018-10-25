proxy_url=http://10.10.10.10:8080/
export http_proxy=${proxy_url}
export https_proxy=${proxy_url}
export no_proxy="127.0.0.1,localhost"
export HTTP_PROXY=${http_proxy}
export HTTPS_PROXY=${https_proxy}
export NO_PROXY=${no_proxy}
