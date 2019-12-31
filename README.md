Source code for my personal blog, hosted at http://www.seancarpenter.io

To fetch the this repo and associated submodules (such as the zzo theme), call:

    git clone --recurse-submodules https://github.com/Seancarpenter/Blog

### Todo

POC
SSL

### Running The Server

To run a local version of the server, navigate to the blog directory and run

    python -m flask run

To expose the server to the whole world, run

    python -m flask run --host=0.0.0.0 --port=80

To enter debug mode (and subsequently enable hot reloading), set the `FLASK_ENV` value to `development`

    export FLASK_ENV=development

### Helpful Resources

    https://flask.palletsprojects.com/en/1.1.x/quickstart/

### Hugo

Uses the zzo theme: https://github.com/zzossig/hugo-theme-zzo
