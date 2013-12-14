express = require("express")
routes = require("./routes")
user = require("./routes/user")
http = require("http")
path = require("path")
flash = require("connect-flash")
passport = require("passport")
LocalStrategy = require("passport-local").Strategy
passport.use new LocalStrategy((username, password, done) ->
  if username is "user" and password is "pass"
    done null,
      id: 1

  else
    done null, false,
      message: "Incorrect"

)
app = express()
passport.serializeUser (user, done) ->
  done null, user.id

passport.deserializeUser (id, done) ->
  done null,
    id: id



# all environments
app.set "port", process.env.PORT or 3000
app.set "views", path.join(__dirname, "views")
app.set "view engine", "jade"
app.use express.favicon()
app.use express.logger("dev")
app.use express.json()
app.use express.urlencoded()
app.use express.methodOverride()
app.use passport.initialize()
app.use passport.session()
app.use express.cookieParser("keyboard cat")
app.use express.session(cookie:
  maxAge: 60000
)
app.use flash()
app.use app.router
app.use express.static(path.join(__dirname, "public"))

# development only
app.use express.errorHandler()  if "development" is app.get("env")
app.get "/", routes.index
app.get "/users", user.list
app.post "/login", passport.authenticate("local",
  successRedirect: "/users"
  failureRedirect: "/"
  failureFlash: true
)
http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")
