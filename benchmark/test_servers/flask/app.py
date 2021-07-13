from waitress import serve

from flask import Flask

SECRET_KEY = b"\xd8p\xff\xac\xceN\xf7\x98\x1a\xef&@i/\xbfZ"
app = Flask(__name__)


@app.route("/")
def hw():
    return "hello world"


@app.route("/<id>")
def lorem(id):
    return f"""
    {id}
    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque
    euismod dui nisl, ac dictum leo imperdiet vel. Vestibulum tincidunt augue a
    enim ullamcorper aliquam. Etiam vel iaculis nunc, cursus dapibus mi.
    Vivamus in ex nulla. Aliquam maximus, odio at pulvinar scelerisque, felis
    leo pellentesque lacus, quis suscipit nulla metus a neque. Phasellus et sem
    a purus placerat ornare sit amet ut ipsum. Donec semper elit lacus, vel
    posuere leo porta sit amet. Lorem ipsum dolor sit amet, consectetur
    adipiscing elit. Sed at sapien mi. Nullam scelerisque porta hendrerit.
    Nulla molestie consectetur enim ac venenatis. Duis euismod viverra magna,
    at pharetra risus sagittis ac. Ut mollis nibh augue, quis tristique sem
    interdum in. Donec ac luctus quam, eu dapibus massa. Aliquam maximus tempus
    volutpat. Cras sagittis lorem ut arcu tempor, a vehicula turpis vehicula.

    Donec aliquam risus a porta malesuada. Curabitur placerat odio in risus
    pretium, in laoreet nisi egestas. Praesent accumsan imperdiet semper.
    Maecenas gravida placerat neque, ac porta dui vehicula a. Vivamus blandit
    tempus tincidunt. Duis euismod at mi ut porttitor. Integer tortor libero,
    tempus ullamcorper fermentum ut, volutpat vitae eros. Duis enim orci,
    dignissim sed diam nec, pellentesque sagittis eros. Integer vitae ultricies
    magna, nec consequat velit. Nulla volutpat augue ultricies feugiat
    tristique. Quisque porttitor gravida quam, id fermentum ex fermentum ac.
    Praesent a pretium odio. Nam lacinia tincidunt purus, eu convallis arcu
    posuere ut. Sed auctor lobortis venenatis.

    Phasellus at leo euismod lectus iaculis ultricies. Nunc sagittis dolor sit
    amet dictum hendrerit. Phasellus egestas nisi tellus, sed accumsan enim
    commodo eu. Etiam eu ante eget mauris molestie egestas nec vel eros. Cras
    ut sapien eget nulla imperdiet condimentum ut ut ipsum. In ultricies sit
    amet ante vitae tempus. Donec dignissim sollicitudin libero id tristique.
    Etiam sollicitudin odio lacus, eu tincidunt arcu mattis ac.

    Quisque id quam scelerisque, luctus leo eu, pretium odio. Pellentesque
    habitant morbi tristique senectus et netus et malesuada fames ac turpis
    egestas. Nam malesuada auctor tellus at elementum. Phasellus euismod mauris
    massa, a ornare nisl tempus quis. Proin mattis commodo libero. In sed quam
    a nibh porta bibendum. Sed tristique elit et lobortis bibendum. In iaculis
    a augue sit amet volutpat. Ut ac tristique lectus, vel fermentum arcu. Sed
    scelerisque, metus in aliquam fermentum, neque quam cursus ante, a
    vulputate urna augue in turpis. Sed non enim ut quam bibendum tempor.
    Phasellus sagittis libero enim, et consequat lectus luctus et. Integer
    facilisis arcu tortor, vel consequat orci placerat sed. Duis rhoncus arcu
    sed faucibus sagittis. Sed eleifend imperdiet placerat. Etiam sodales ipsum
    id nisl ultrices mollis.

    Etiam leo magna, vulputate eu sodales non, aliquet in lorem. Praesent
    ornare a elit vel pulvinar. Donec nec viverra ipsum. Etiam orci arcu,
    iaculis eget dolor a, molestie laoreet augue. Maecenas pretium sagittis
    eros, non tempor metus ultricies lacinia. Vivamus accumsan justo diam,
    et bibendum urna mattis vitae. Sed tincidunt sapien quis dui iaculis, non
    egestas lacus finibus. Phasellus nec pharetra odio.
    """


serve(app, host="0.0.0.0", port=8080)
