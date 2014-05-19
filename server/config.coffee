module.exports =
  buckets:
    adminSegment: 'admin'
    apiSegment: 'api'
    salt: 'BUCKETS4LIFE!!1'
    port: process.env.PORT or 9090
    env: process.env.NODE_ENV or 'development'
  rethinkdb:
    host: 'localhost'
    port: 28015