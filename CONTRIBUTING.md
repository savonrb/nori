# Contribution Guide

This page describes how to contribute changes to Nori.

Please do not create a pull request without reading this guide first.

**Bug fixes**

Nori turns an XML string into a Ruby hash. If you think you found a bug, the most useful
input you can give us is: the XML input, the hash you got back, and the hash you expected.
You're a developer, we are developers, and you know we need a test to reproduce a problem
and make sure it does not come back.

So if you can reproduce your problem in a spec, that would be awesome! If the behavior differs
between the Nokogiri and REXML parsers, please say which parser you were using, because that is
often the key to the bug.

After we have a failing spec, it needs to be fixed. Make sure your new spec is the only failing
one under the `spec` directory.

**Running tests**

```bash
bundle install
bundle exec rspec
```

Before opening a pull request, also run the checks CI runs so you don't get a red build:

```bash
bundle exec rubocop
```

Please follow this workflow for Pull Requests:

* [Fork the project](https://help.github.com/articles/fork-a-repo)
* Create a feature branch and make your bug fix
* Add tests for it!
* [Send a Pull Request](https://help.github.com/articles/using-pull-requests)
* [Check that your Pull Request passes the build](https://github.com/savonrb/nori/actions/workflows/ci.yml)

**Improvements and feature requests**

If you have an idea for an improvement or a new feature, please feel free to
[create a new Issue](https://github.com/savonrb/nori/issues/new/choose) and describe your idea
so that other people can give their insights and opinions. This is also important to avoid
duplicate work.

Pull Requests and Issues on GitHub are meant to be used to discuss problems and ideas, so please
make sure to participate and follow up on questions. In case no one comments on your ticket,
please keep updating the ticket with additional information.
