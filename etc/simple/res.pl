use Mojo::Message::Response;

    my $res = Mojo::Message::Response->new;
    $res->code(200);
    $res->headers->content_type('text/plain');
    $res->body('Hello World!');

    print $res->to_string;
