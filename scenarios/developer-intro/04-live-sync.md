In addition to being able to manually upload or download files when you choose to, the ``oc rsync``
command can also be set up to perform live synchronization of files between your local computer and the container.

That is, the file system of your local computer will be monitored for any changes made to files.
When there is a change to a file, the changed file will be automatically copied up to the container.

This same process can also be run in the opposite direction if required, with changes made in the
container being automatically copied back to your local computer.

An example of where it can be useful to have changes automatically copied from your local computer
into the container is during the development of an application.

For scripted programming languages such as JavaScript, PHP, Python or Ruby, where no separate compilation
phase is required you can perform live code development with your application running inside of OpenShift.

For JBoss EAP applications you can sync individual files (such as HTML/CSS/JS files), or sync entire application
.WAR files. It's more challenging to synchronize individual files as it requires that you use an *exploded*
archive deployment, so the use of [JBoss Developer Studio](https://developers.redhat.com/products/devstudio/overview/) is
recommended, which automates the process (see [these docs](https://tools.jboss.org/features/livereload.html) for more info).

## Live synchronization of project files

For this workshop, we'll Live synchronize the WAR file.

First, click on the [Coolstore application link](http://www-coolstore-monolith-dev.[[HOST_SUBDOMAIN]]-80-[[KATACODA_HOST]].environments.katacoda.com)
to open the application in a browser tab so you can watch changes.

**1. Turn on Live Sync**

Turn on **Live sync** by executing this command:

`oc rsync deployments/ [POD]:/deployments --watch --no-perms &`{{execute}}

> Be sure to replace `[POD]` with the name of the pod which you can get from `oc get pods --show-all=false`{{execute}}

Now `oc` is watching the `deployments/` directory for changes to the `ROOT.war` file. Anytime that file changes,
`oc` will copy it into the running container and we should see the changes immediately (or after a few seconds). This is
much faster than waiting for a full re-build and re-deploy.

**2. Make a change to the UI**

Next, let's make a change to the app that will be obvious in the UI.

First, open `src/main/webapp/app/css/coolstore.css`{{open}}, which contains the CSS stylesheet for the
Coolstore app.

Add the following CSS to turn the header bar background to Red Hat red (click **Copy To Editor** to automatically add it):

<pre class="file" data-filename="src/main/webapp/app/css/coolstore.css" data-target="append">

.navbar-header {
    background: #CC0000
}

</pre>

**2. Rebuild application For RED background**

Let's re-build the application using this command:

`mvn package -Popenshift`{{execute}}

This will update the ROOT.war file and cause the application to change.

Re-visit the app by reloading the Coolstore webpage (or clicking again on the [Coolstore application link](http://www-coolstore-monolith-dev.[[HOST_SUBDOMAIN]]-80-[[KATACODA_HOST]].environments.katacoda.com)).

You should now see the red header:

**3. Rebuild again for BLUE background**

Repeat the process, but replace the background color to be blue (click **Copy to Editor** to do this automatically):

<pre class="file" data-filename="src/main/webapp/app/css/coolstore.css" data-target="insert" data-marker="background: #CC0000">
background: blue
</pre>

Again, re-build the app:

`mvn package -Popenshift`{{execute}}

This will update the ROOT.war file again and cause the application to change.

Re-visit the app by reloading the Coolstore webpage (or clicking again on the [Coolstore application link](http://www-coolstore-monolith-dev.[[HOST_SUBDOMAIN]]-80-[[KATACODA_HOST]].environments.katacoda.com)).

It's blue! You can do this as many times as you wish, which is great for speedy development and testing.

## Before continuing

Let's kill the `oc port-forward` processes we started earlier in the background. Execute:

`kill %1`{{execute}}

On to the next challenge!