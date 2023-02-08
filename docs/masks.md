# Masks

A mask gives you the smooth gradient that you see between the title image, and the background. Choosing the right mask will give you the look and feel that you want.

## Using masks

* You choose which mask you want to use with the `mask=` setting in the `config` file in the root of your site project.
* It defaults to `none.jpg`.
* You can see the available masks by looking in the assets/masks folder of this project.
    * You don't need to specify the path. The filename is enough.

## Creating new masks

If you want a different look, you can create a new mask.

### Steps

1. Check back here first. - These instructions are very likely to evolve.
1. Create a new layer in assets/masks/masks.xcf .
    * Give it a meaningful name.
    * White is opaque. Black is transparent. Grey is in partially transparent.
1. Edit `extractMasks` to include the new layer.
    * Add the layer in this section:
        ```
        name gradient-010
        name gradient-025
        name gradient-050
        ```
    * The layer names should be in the same order. Otherwise the final filenames will not match.
1. Run `extractMasks` to get the new masks.
