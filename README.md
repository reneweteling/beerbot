# Beerbot

Beerbot is a simple Rails backend mainly with the ActiveAdmin gem, and a small json resource to power the fluxxor/react frontend.
And you guessed it. Its an SPA to count to keep track of those pesky beers. They just seem to vaporise dont they. 

## Todo

#### Must have's
* [ ] Stick cable thing on wall, adapter is ugly
* [ ] Implement CircleCi
* [ ] Write tests
* [ ] Automaticly deploy to heroku-dev if tests pass
* [ ] Remove basic auth
* [ ] Authenticate SPA ( place behind login )
* [ ] Add fastclick
* [ ] Add a bought page ( add per 6 or per 24 )
* [ ] Add a polling mechanism that checks the sha1 to see if there is a change, if so update the store and play the bottle sound
* [ ] Deploy somewhere
    * [ ] Add Mina

#### Nice to have's
* [ ] Make it pretty HELP!!!! i suck ballz at this
* [ ] Add slack bot integration ( project already ready on laptop Rene )
* [ ] Add wise ass slack responses ( maybe check if there is a wise ass funny API or canned responses database )
* [ ] Only add beer though slack if the user is singed in to the building ( link with Joris his API )

## Usage

* clone repo
* bin/bundle
* bin/rake db:create db:migrate db:seed
* bin/rails s
* go to http://localhost:3000 for the SPA
* go to http://localhost:3000/admin for the admin interface

#### Credentials dev environment

* basic auth
    * beer / beer
* admin
    * rene@weteling.com / password

## Contributing

* Fork the repo.
* Make sure the tests pass:
* Make your change, with new passing tests. 
* Push to your fork. Write a [good commit message][commit]. 
* Submit a pull request.

  [commit]: http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html

Others will give constructive feedback.
This is a time for discussion and improvements,
and making the necessary changes will be required before we can
merge the contribution.

## License

Beerbot is Copyright (c) 2015 Weteling Support.
It is free software, and may be redistributed
under the terms specified in the [LICENSE] file.

  [LICENSE]: /LICENSE

## About

Beerbot is maintained by René Weteling.

![René Weteling](http://www.weteling.com/zzz/footer.png)

Beerbot is maintained and funded by Weteling Support.

I love open source software!
See [my other projects][blog]
or [hire me][hire] to help build your product.

  [blog]: http://www.weteling.com/
  [hire]: http://www.weteling.com/contact/