# How to use?

1. Duplicate security.yml from security.yml.sample
2. Write your asp account's id and password in security.yml

For example

```yml
a8:
  id:
  password:
felmat:
  id: mc-chinju
  password: abcd1234567890
access_trade:
  id:
  password:

...
```

3. Execute following commands

```
$ bundle install
$ bundle exec ruby main.rb
```

4. Output `data.csv` file!
