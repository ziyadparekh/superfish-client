# superfish-client
iPhone client for superfish

This repository hold the iPhone app that runs Superfish.

Superfish (a working title) is an app that combines texting and Github's Hubot. Most implementations of a chat app with Hubot have this extra step of having to have your own Hubot instance running and configuring user tokens and access controls to allow you to use it within your company or organization (think Slack or HipChat). The idea for this app was to make a batteries included Hubot integration into Messaging. Hubot comes fully integrated in this group messaging app.

While still in early stages and requiring polishing up, this app is fully functional and can be run on your simulator or iOS device (if you have Apple Developer Membership). I will update the README with screen shots and gif videos soon but to give you an idea this is what it can do:

1. Addressbook access to filter your contacts with those currently using the app
2. Create groups of one to x people.
3. Have group conversations with your friends (pretty regular stuff)
4. Hubot is integrated by default in every group that is created and is accessible using the `Hubot <query>` command
5. Pressing `:` followed by commands will bring up an autocomplete for common hubot commands
6. Support for images, GIFS and other links that Hubot replies with
7. Integrated WebView to open links within the group messenger so that you dont have to leave the app
8. Integrated Image/GIF view so you can view them in full screen with pan and zoom support

I think Hubot is really cool and the fact that Github opened sourced it makes it even more powerful. Integrating Hubot inside a group messenger application isn't something new. I originally started this to teach my Go, Objective C, iOS development and Hubot! I showed it around to some friends and they thought it was pretty cool so I thought I'd open it up to the wider community to see what could be made of this.

Let me know if you have any questions and check out the backend for this repo [here](https://github.com/ziyadparekh/superfish)

I will try to update the documentation but in the meantime try file issues if you have trouble running it and hit me up on Twitter if you need anything [@ziyadparekh](https://twitter.com/ziyadparekh)
