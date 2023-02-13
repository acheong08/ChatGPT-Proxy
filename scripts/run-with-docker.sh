docker run -d --name=chatgpt-proxy --network host devmitrandir/chatgpt-proxy:latest \
&& echo -e "chatgpt-proxy container started" \
&& echo -e "View logs:\n  docker logs --tail 1000 -f chatgpt-proxy" \
&& echo -e "Stop container:\n  docker stop chatgpt-proxy"