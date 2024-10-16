# Codename-B

Codename-B is an innovative 2D shooter game inspired by "Vampire Survivors", "Brotato", and "Death Must Die". It is developed using Java 17 with Spring Boot for the backend, Docker for PostgreSQL, Angular 17 for the frontend, and Godot 4.3 Dev 3 for game development.

## Table of Contents

- [Description](#description)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Test Forgot Password](#test-forgot-password)


## Description

Codename-B is a 2D shooter game designed to provide an exciting and challenging gaming experience. Players engage in dynamic battles against various enemies, utilizing a range of characters and weapons. Developed with modern web technologies, Codename-B ensures a seamless and immersive gaming experience directly in your browser.

## Features

- Dynamic 2D shooter gameplay
- Multiple levels and enemy types
- Various characters and weapons to choose from
- Seamless integration with web technologies
- Regular updates and expansions to enhance gameplay
- Intuitive and engaging user interface

## Prerequisites

Before you begin, ensure you have met the following requirements:

- Java 17 JDK installed.
- Node.js and npm installed for Angular frontend.
- Docker installed for running PostgreSQL.
- Godot Engine 4.3 Dev 3 installed for game development.

## Installation

1. Clone the repository: git clone https://github.com/ScriptSavvySquad/Codename-B.git
2. Navigate to the docker directory: cd Codename-B/Backend/codenameb/docker
3. Run the Postgresql database (make sure docker is running): docker compose up
4. Navigate to the backend directory: cd Codename-B/Backend/codenameb
5. Build and run the Spring Boot application: ./mvnw spring-boot:run
6. Navigate to the frontend directory: cd Codename-B/Frontend/codenameb
7. Install Angular dependencies: npm install
8. Run the Angular application: npm start

## Usage

Once the application is running, you can access the frontend by navigating to http://localhost:4200

setup.data.email = gerergfrefererf@byom.de
setup.data.password = Admin123?!

## Test Forgot Password

To test the forgot password functionality you can login on byom.de with gerergfrefererf@byom.de. In the mail click on "Text". The Mailserver is only working with that mail because of test restrictions.
