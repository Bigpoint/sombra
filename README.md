# Sombra
---
Sombra is a small rails application to provide [Json Web Tokens](https://jwt.io/). Sombra's users
are managed through a RESTful api.

### Getting started
The easiest way to get Sombra up and running is using docker with the provided docker-compose.yml.
This will start sombra and its dependencies as containers. To get sombra up, run the following commands:

```
touch Gemfile.lock
docker-compose up -d --build
docker exec -it sombra_app_1 rake db:reset
```

Afterwards you can access sombra by pointing your browser towards:

http://127.0.0.1:8080/

You will be greeted by a json output similar to this:

```
{
  "IAm": "sombra",
  "Pubkey": "-----BEGIN PUBLIC KEY-----\nMFkw...CvRJQ==\n-----END PUBLIC KEY-----\n"
}
```

** Do not use this way in production! ** See below how to set it up properly.

---

### Using Sombra
By default the ```rake db:reset``` task will generate two users within the document database:
  * **admin**: with password "admin" and role "admin"
  * **firstapp**: with password "foobar" and role "application"

It is highly recommmended to change the admin password. To do so, we need to get
a valid JWT first. You want to execute the following curl:

```
curl -X POST -H "Content-Type: application/json" \
 -d '{"auth":{"name":"admin","password":"admin"}}' \
 http://your.sombra.host:8080/user_token
```
The result will look like this:
```
{
  "jwt": "eyJ0eXAIoIJKV1Qi..."
}
```
Now, as we've got a token, we need to find the admin user id:

```
curl -X GET -H "Content-Type: application/json" \
 -H "Authorization: bearer eyJ0eXAIoIJKV1Qi..." \
 http://your.sombra.host:8080/users
```
Note that we add the **eyJ0eXAIoIJKV1Qi...** (the jwt) to the request
as a bearer authorization header.

This will result in a json array of users. Find the $oid field in the output for
the admin user. It should look like "***585...***".

Now we finally can update the admin user password:

```
curl -X PUT -H "Content-Type: application/json" \
 -H "Authorization: bearer eyJ0eXAIoIJKV1Qi..." \
 -d '{"user":{"password":"YOURNEWPASSWORD"}}' \
 http://your.sombra.host:8080/users/585...
```
Make sure to use the correct id on the url.
Your jwt will still be valid, but you will not be able to refresh the token
without providing the changed password.

Consider deleting the ***firstapp*** user:

```
curl -X DELETE -H "Content-Type: application/json" \
 -H "Authorization: bearer eyJ0eXAIoIJKV1Qi..." \
 http://your.sombra.host:8080/users/THE$OIDFORFIRSTAPP
```

To create a new user, simply call sombra with a POST request:
```
curl -X POST -H "Content-Type: application/json" \
 -H "Authorization: bearer eyJ0eXAIoIJKV1Qi..." \
 -d '{"user":{"name":"MYNEWUSER","password":"YOURNEWPASSWORD","role":"application"}}' \
 http://your.sombra.host:8080/users/
```

Further documentation on Sombra's API can be found in the doc/ folder.

---

### Verifying JWTs
By default Sombra will use ECDSA256 to sign tokens. This way your application does not
have to store a private key to verify the token. Your application however needs to
either be deployed having Sombra's public key or aqcuire it by a request to
Sombra's index (GET /).

Sombra does not provide a way for key rollover. You should also not cache the public key.
If you deploy the pubkey with your app, you will need to redeploy the app once the
keypair was changed within Sombra.

We might add JWK for this in the future.

---

### How to run Sombra in production environments
We do not deliver a straight out of the box, production ready setup. Depending
on your usecase, our way might be over the top or too secure. Some good practices:

  * Run multiple Sombra app servers:
    As Sombra exposes its pubkey for verification, your app/apps might send a lot of requests.
    Horizontal scaling is especially useful if Sombra is used with customer interactions (a lot of users asking for JWTs).
    An easy way to achieve this is to put ta reverse proxy in front of your Sombras (like nginx, traefik, ha-proxy).

  * Run Sombra behind a TLS enabled reverse proxy:
    As your app/apps/customers are sending their login credentials towards Sombra, it is highly recommended to put
    a TLS enabled reverse proxy in front (e.g. traefik has builtin Let's Encrypt support).

  * Rotate the ECDSA256 keypair often:
    Another good practice is to rotate Sombra's keys often.

  * Run multiple Sombra setups instead of one big one. Aim for fast deployments, not centralization.

A recommended setup:
  * Redis as container. Redis is used for rate-limiting.
  * MongoDB as a service / as VM / as baremetal. In our humble opinion it is currently (2016) highly
    discouraged to run persistant data based applications within containers. MongoDB is used as storage backend.
  * traefik as reverse proxy with ACME enabled in front of Sombra containers.
  * Setting RAILS_ENV=production for Sombra containers.
  * Using [filebeat](https://elastic.co/en/products/beats) to transfer logs to elastic stack.
  * Set SOMBRA_UNICORN_CONCURRENCY to amount of CPU cores - 1.
  * Use DNS roundrobin over multiple traefik loadbalancers.
  * Have a repo containing a script to update Sombra's users. Make this your single point of truth for user configuration.


---

### Configuration
Sombra is configurable through environment variables:

| Variable  | Default | Required | Description |
| --------- |:-------:|:----------:|--------------|
| SECRET_KEY_BASE | nil | yes | A long string which is used by Rails to secure sessions and more.|
| SOMBRA_TOKEN_SECRET_PRIVATE | nil | yes | Your ECDSA256 privat key (pem, 1 line, see config/secrets.yml for example, see https://github.com/jwt/ruby-jwt ECDSA how to generate one).|
| SOMBRA_TOKEN_SECRET_PUBLIC | nil | yes | Your ECDSA256 public key (pem, 1 line). It has to match your privatekey.|
| SOMBRA_TOKEN_ISSUER | nil | yes | A name for your Sombra setup. This is used in the JWT iss claim.|
| SOMBRA_TOKEN_EXPIRATION_IN_S | 3600 | no | Token expiration in seconds.|
| SOMBRA_REDIS_HOST | redis | no | The name of your redis host.|
| SOMBRA_REDIS_PORT | 6379 | no | The redis port on your redis host.|
| SOMBRA_REDIS_DATABASE | 0 | no | The db number on your redis host for Sombra.|
| SOMBRA_REDIS_PASSWORD | foobar | no | The password used to AUTH at your redis.|
| SOMBRA_MONGODB_HOST | nil | yes | The address of your MongoDB.|
| SOMBRA_MONGODB_USER | nil | yes | The user for MongoDB.|
| SOMBRA_MONGODB_PASSWORD | nil | yes | The password for MongoDB.|
| SOMBRA_MONGODB_ROLES | nil | yes | The auth user's dbRoles for MongoDB.|
| SOMBRA_MONGODB_AUTH_SOURCE | nil | yes | The db within MongoDB to auth against.|
| SOMBRA_MONGODB_MAX_POOL_SIZE | nil | yes | Maximum concurrent connections to MongoDB per worker.|
| SOMBRA_MONGODB_MAX_POOL_SIZE | nil | yes | Minimum concurrent connections to MongoDB per worker.|
| SOMBRA_UNICORN_CONCURRENCY | 3 | no | Number of workers to be spawned (should be cpu cores - 1).|
| SOMBRA_RATE_LIMIT_REQUESTS | 300 | no | Number of requests per IP before throttling.|
| SOMBRA_RATE_LIMIT_PERIOD_IN_S | 10 | no | Period for requests. E.g. 300 reqs within 10s by one IP.|

---

### Development
#### Environment
Easiest way to develop Sombra is running the included docker-compose.yml.
Make sure to rebuild your containers on changes. Depending on your OS you can also mount
the source into the app container. This way rails will reload changed files (except initializers).
#### Tests
Sombra's testing consists of integration tests. To run the tests:
```
RAILS_ENV=test SOMBRA_MONGODB_HOST="mongodb:27017" rake db:reset && rails test
```
Please lint your code using rubocop. 3rd party gems and their initializers should be ignored in linting.

#### Documentation
All environment variables need to be added to the README.md. Inline documentation
should include why you are doing something. Stick to rdoc with @tags please.
To generate the doc:

```
yard doc
```
#### Contribution
Fork this repo, change stuff, open a pull request. We will review your additions.

---

### Why Sombra?
Boop! This software's name was inspired by Blizzard's lovely character design.

---

### License
Sombra is released under the
[MIT License](https://github.com/Bigpoint/sombra/blob/master/LICENSE.md).
