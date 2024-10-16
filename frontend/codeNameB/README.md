# CodeNameB

# Dockerization

In this section we'll explain how to run the application with Docker, in each stages (Dev, Prod)

## Development

### Run the Frontend Dev Application

<code>docker compose --profile frontend-dev up --watch</code>

### Run the Backend with its Database

<code>docker compose --profile backend up</code>

### Run the whole application for development

<code>docker compose --profile frontend-dev --profile backend up --watch</code>

## Production

### Run the Frontend Prod Application

<code>docker compose --profile frontend-prod up --watch</code>

## Misc Tasks

### Run only the database

<code>docker compose --profile db up</code>

### Export the game

<code>docker compose --profile game-export up</code>

To run any of the profiles detached add the <code>-d</code> flag at the end of each command.

To rebuild any docker image run any command with --build
