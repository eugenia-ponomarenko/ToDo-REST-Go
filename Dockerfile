FROM scratch

COPY ./configs ./configs
COPY ./.env ./.env
COPY ./todo-app ./todo-app

EXPOSE 8000

CMD ["./todo-app"]
