# Notes to myself

## Cabal notes

When I edit site.hs, it seems like I have to run `cabal install site --overwrite-policy=always` to get the changes to take effect if I want to be able to use `site build` or `site watch`. But if I do `cabal run site rebuild` then `cabal run site watch` the `cabal run` seems to work the same as the `stack exec` I see in the tutorials, and doesn't require the install with overwrite flat. I think I'll stick to the `cabal run` approach since that mirrors the tutorials more, but clearly I should learn more about what the heck cabal and stack are doing here!

## Misc

Using this command `find . -type f -exec sed -i 's/{:target="_blank"}//g' {} \;` to remove all the special kramdown open links in new window stuff that Hakyll doesn't support (and that I don't really want anymore anywas) was cool!
