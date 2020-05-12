# Contributing to BeEF

Anyone is welcome to make BeEF better!

Below are the steps needed to add code to BeEF on Github to the master branch:

1. Clone the repository and create a new branch

2. Write and commit your new code to that branch

3. Run the existing tests to make sure they pass

See https://github.com/beefproject/beef/wiki/BeEF-Testing for steps to write tests.

TL;DR: 
```
bundle install --with test
bundle exec rake spec
```

4. Write tests in RSpec for your new code (module, extension etc.)

5. Run all tests again to make sure they all pass

6. Edit existing wiki page / add a new one explaining the new features, including:
	- sample usage (command snippets, steps and/or screenshots)
	- internal working (code snippets & explanation)

7. Submit a Pull Request, explaining:
	- what you have added
	- where to find help about it (link to wiki page)

If you're brand new to contributing to open-source projects, check out Githubs guide:
https://github.com/firstcontributions/first-contributions/blob/master/README.md
