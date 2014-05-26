module.exports =
  buckets:
    adminSegment: 'admin'
    apiSegment: 'api'
    salt: 'BUCKETS4LIFE!!1'
    port: process.env.PORT or 3000
    env: process.env.NODE_ENV or 'development'
  db: "mongodb://localhost/buckets_#{process.env.NODE_ENV or 'development'}"