This is the directory where the cloned pages will be placed.
If you clone beefproject.com, there will be 2 files:
 - beefproject.com  <- original, unmodified
 - beefproject.com_mod  <- modified one

In case you want to further modify the beefproject.com_mod manually,
and serve it through BeEF, do the following:
 - clone the page
 - modify the beefproject.com_mod file
 - clone the same page again, adding the "use_existing":"true" parameter in the RESTful API call.

In this way the x_mod page will be served, with your custom modifications.