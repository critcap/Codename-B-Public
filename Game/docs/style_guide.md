# Styleguide

- [1. Conventions used in this document](#conventions-used-in-this-document)
- [2. Naming](#file-naming)
- [3. Resource Naming](#resource-naming)
- [4. Code](#code)

---

<a name="terms-conventions-used"></a>

## Conventions used in this document

- `snake_case` is **like_this**.
- `camelCase` is **likeThis**.
- `PascalCase` is **LikeThis**.
- `UPPER_SNAKE_CASE` is **LIKE_THIS**.

---

<a name="terms-naming"></a>

## Naming

- Use `UPPER_SNAKE_CASE` for constants and enums.
- Use `snake_case` for variables and functions.
  - Prefix private variables and functions with `_`.
  - Prefix unused arguments of methods with `_` (e.g. func my_func(\_unused_arg) -> void:).
- Use `snake_case` for input map names.
- Use `snake_case` for all script file names.
- Use `PascalCase` for all scene and resource file names e.g. `.tres`, .`tscn` etc. For further resources naming please look at [Resource Naming](#terms-resource-naming)
- Use `PascalCase` for node names.
- Use `PascalCase` for classes.

---

<a name="terms-resource-naming"></a>

### Resource Naming

| Asset Type               | Prefix | Suffix | Notes                             |
| ------------------------ | ------ | ------ | --------------------------------- |
| Texture                  | T\_    |        |                                   |
| Texture (Spritesheet)    | SPR\_  |        | _Resource of AnimatedSprite Node_ |
| Texture (AtlasTexture)   | ATL\_  |        |                                   |
| TileSet                  | TS\_   |        | _Resource of TileMap Node_        |
| TileMap (.tscn)          | TM\_   |        | _Saved TileMap Scene_             |
| Material/Shader          | M\_    |        |                                   |
| Music                    | BGM\_  |        |                                   |
| Sound Effects            | SFX\_  |        |                                   |
| Animations               | A\_    |        |                                   |
| Animations (Library)     | ALIB\_ |        |                                   |
| UI Scenes (.tscn)        | UI\_   |        |                                   |
| UI Widget Scenes (.tscn) | UC\_   |        | _part of an UI Scene_             |
| Fonts                    | Font\_ |        |                                   |
| Maps                     | Map\_  |        | _should be in src/maps/_          |

---

<a name="terms-code-naming"></a>

## Code

- **Use types everywhere you can!**
  - You can omit return types in build-in virtual methods like `_ready()`, `_unhandled_input` etc.
  - Types can also be omitted on unused method arguments.

For code style reference look here <a href="https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html">GDScript Styleguide</a>
