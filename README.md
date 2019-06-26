# Go-Eat

Thanks for using Go-Eat! Order your food now – all you need to do is just order the food from the restaurant that are available on the apps.

HOW TO USE GO-EAT

1. Select your restaurant – Select your favorite restaurant
2. See the menu and your food cost – We’ll let you know how much the food costs, then ORDER GO-EAT when you’re have done
3. Pay in cash – Currently, Go-Eat only accept cash payment
4. Take the food – Get ready as the nearest driver-partner makes their way to you, then you can take the food that you have already ordered
4. Enjoy the food

MAP LEGEND
R – Restaurant
D – Driver
@ – You

```
# # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # #
# # # # # D # # # # # # # # # # # # # #
# # # #     # #         # # # # # # # #
# # # #                 # # # # # # # #
# # #                       # # # # # #
# #                     R   # # # # # #
# # # R                   # # # # # # #
# # # # D               R   # # # # # #
# # # # #   D                 # # # # #
# # # # #           @       # # # # # #
# # # # #                 D # # # # # #
#     #           # #         # # # # #
#                   # #         # # # #
#                 # # #           # # #
#                 # # #     #       # #
# #                 # # # # # #   D   #
# #                   # # # # # #   # #
# # # #           # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # #
```

## Usage

There's 3 way to use Go-Eat

### Without any argument

```
ruby lib/goeat.rb
```

### With file path as it's argument

```
ruby lib/goeat.rb spec/example.toml
```

### With 3 arguments

```
ruby lib/goeat.rb MAP_SIDE_SIZE USER_X_POSITION USER_Y_POSITION
```

e.g

```
ruby lib/goeat.rb 20 10 10
```

There's a border on the map so you can't make the user on the border, in this case USER_X_POSITION as 0 or USER_X_POSITION as 10 (as the coordinate starts from 0).

## Why TOML?

I choose TOML simply because it's more human-readable and the format is much more simple especially for a nested list or dictionary.

## License

The application is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).