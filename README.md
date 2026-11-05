# MoganLab Goldfish

## How do I install these goldfish?
```
brew tap MoganLab/goldfish
brew install goldfish
```

## How do I update only the goldfish tap?

`brew update` refreshes Homebrew/core and every tap at once. To update just this
tap, pull its git repository directly:

```sh
git -C "$(brew --repo moganlab/goldfish)" pull --ff-only
```

To hard-reset the tap to the upstream state (discarding local changes):

```sh
git -C "$(brew --repo moganlab/goldfish)" fetch origin --prune
git -C "$(brew --repo moganlab/goldfish)" reset --hard origin/main
```

Then upgrade the formula without letting Homebrew auto-update everything else:

```sh
HOMEBREW_NO_AUTO_UPDATE=1 brew upgrade goldfish
```

## Documentation

`brew help`, `man brew` or check [Homebrew's documentation](https://docs.brew.sh).
