# FastAPI Starter

This template serves the purpose of making it simple for starting a FastAPI backend.

Likewise, this project assumes you have the necessary package installers, similar to the other starter templates.

In this case, we will use `uv`, which is the latest package manager written in Rust, offering unparalled speeds and low overhead, whilst combining all the features of `pip`, `pipx`, `poetry`, and so on all into one.

To begin, we install `FastAPI` first:

```sh
    uv init
    uv add "fastapi[standard]" uvicorn
```

Then, as per the `FastAPI` documentation, we create a `main.py` with the following code:

```py
    from typing import Union

    from fastapi import FastAPI

    app = FastAPI()


    @app.get("/")
    async def read_root():
        return {"Hello": "World"}


    @app.get("/items/{item_id}")
    async def read_item(item_id: int, q: Union[str, None] = None):
        return {"item_id": item_id, "q": q}
```

And run the following command in the terminal:

```sh
    fastapi dev main.py
```

Navigate to <http://127.0.0.1:8000> or <http://127.0.0.1:8000/docs>, and see if you see the JSON response or the SwaggerUI respectively.

However, we will introduce a new feature of FastAPI here, which is `uvicorn`, that which is fully compatible with it as a AGSI web server.

To use it, just run the following command:

```sh
    uvicorn main:app --host 0.0.0.0 --port 8080 --workers 4
```

- `main:app` calls the `app = FastAPI()` part of our code to start the server and serve it using `uvicorn`.
- `--host <your_ip_address>` specifies what address to serve it on.
- `--port <your_port>` defines the TCP port Uvicorn will listen on.
- Most importantly, `--workers <num_of_workers>` specifies the number of worker processes to spawn. The general rule of thumb is `workers = 2 × CPU cores + 1`.

However, that is for production. For development, use the following command:

```sh
    uvicorn main:app --host 0.0.0.0 --port 8080 --reload
```

With the base server in order, we will now proceed on with linting and best practices.

## Essential packages

Run the following commands to install the packages below:

```sh
    uv add --dev autoflake isort black ruff mypy
```

This will create a `uv.lock` and `pyproject.toml`.

These tools cover formatting, linting, and type checking:

- [autoflake](https://github.com/PyCQA/autoflake) → Removes unused imports and variables.
- [isort](https://github.com/PyCQA/isort) → Sorts imports consistently.
- [black](https://github.com/psf/black) → Auto-formats Python code to a standard style.
- [ruff](https://github.com/astral-sh/ruff) → Fast linter with rules from pylint, flake8, etc.
- [mypy](https://github.com/python/mypy) → Static type checker for Python.

And that's it! It is much simpler than most of the stacks out there.

Commands for each can be looked up on their respective GitHub repositories (linked in the names). Below is an example script if you are dual-stacking this with a Javascript-based frontend, and is using `husky` and `lint-staged`:

```json
    // package.json
    "scripts": {
        "lint:backend": "uv run --cwd packages/backend ruff . && uv run --cwd packages/backend mypy .",
        "format:backend": "uv run --cwd packages/backend autoflake --in-place --remove-unused-variables --remove-all-unused-imports && uv run --cwd packages/backend isort . && uv run --cwd packages/backend black ."
    }

    // .lintstagedrc.json
    "backend/**/*.py": [
        "npm run format:backend",
        "npm run lint:backend"
    ]
```

The above assumes that you have the following directory structure:

```txt
    my-monorepo/
    │── package.json          # root for Husky, lint-staged, etc.
    │── .husky/
    │── .lintstagedrc.json
    │── packages/
    │   ├── frontend/         
    │   └── backend/
```

Else, feel free to change the fields as you wish. They serve only as a guideline.

## Additional configuration

For production deployment, it’s common to containerize your FastAPI app.

A sample `Dockerfile` is included in this project.

```dockerfile
    # Use official Python slim image for small size
    FROM python:3.12-slim

    # Set working directory inside container
    WORKDIR /app

    # Install uv (Rust-based package manager)
    RUN pip install --no-cache-dir uv

    # Copy project files
    COPY . .

    # Install dependencies (frozen to lock file for reproducibility)
    RUN uv sync --frozen --no-dev

    # Expose port the app will run on
    EXPOSE 8080

    # Run FastAPI using Uvicorn with multiple workers for production
    CMD ["uv", "run", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080", "--workers", "4"]
```

Remember to update the last line's last number with the accurate number of workers you want to run.

A `.dockerignore` is also included to reduce bloat and improve image sizes.

```ignore
    # Python cache
    __pycache__/
    *.pyc
    *.pyo
    *.pyd

    # Virtual environments
    venv/
    .env

    # Git files
    .git
    .gitignore

    # Local logs and temp
    *.log
    *.tmp

    # Node / frontend files if in a monorepo
    **/node_modules/
    **/dist/
```

Now you can build and run it with the commmands below:

```sh
    docker build -t <image_name> .
    docker run -p 8080:8080 --name <container_name> <image_name>
```

Replace the `< >` with the respective content, and you are now ready!
