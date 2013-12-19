express = require("express")
routes = require("./routes")

http = require("http")
path = require("path")
flash = require("connect-flash")
passport = require("passport")
LocalStrategy = require("passport-local").Strategy
passport.use new LocalStrategy((username, password, done) ->
  if username is "user" and password is "pass"
    user = id: 1
    app.locals.user = user
    done null, user
  else
    delete app.locals.user
    done null, false,
      message: "Incorrect username or password"
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

# routes
app.get "/", routes.index
app.get "/success", (req, res) ->
  res.render "success"

app.post "/login", passport.authenticate("local",
  successRedirect: "/success"
  failureRedirect: "/"
  failureFlash: true
)

http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")
