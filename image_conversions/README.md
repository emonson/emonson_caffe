## Image conversion script

The idea behind these scripts is to generate a new script every time a new image
conversion set needs to be generated. In the past, it was problematic to either
generate images on a new system, or to regenerate a directory of processed
images when new source sets were added. With one script per image data set, if
the original set had cows, sailboats and windmills from ImageNet, and you find you
want to add carts, you can just rerun the script associated with the specific processing
you want to do, and it'll end up with all of the sets. (It's true that it has to reprocess
all of the images, but it's easy and complete this way.)

When starting on a new system, you need to copy the `server.conf.example` file to a file
called `server.conf` and modify it to reflect the current machine's data directory structures.
The repository updates will ignore changes to `server.conf`.

*NOTE:* Right now these routines do not delete an old generated image directory before
creating the new one, so it's easy to add sets, and earlier-processed images will just
get overwritten, but it won't remove old sets automatically if that's what you're trying
to do. For the latter, just delete the old processed directory manually before you start
and regenerate the whole thing.
