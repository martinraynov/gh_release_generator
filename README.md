# Github Release Generator

Script that allows you to generate Github Releases easily.

## Init of variables
You must specify some variables to be able to generate the release :

- __REPOSITORY__ : This is the path to your repository/application. (Ex : `martinraynov/gh_release_generator`)
- __VERSION__ : This is the version of the tag and the release (Ex : `1.3.6`)
- __GITHUB_TOKEN__ : This is the token that you must configure previously to allow you access to the Github API. (https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token)

## Changelog file

The description in the new release will be taken from the `CHANGELOG.md` file. You must include this file in your repository.

The format must be as defined : 

```
### {RELEASE_NAME}
{DESCRIPTION}
```

## Generation

The entry command is :

```
make build_github_release
```


