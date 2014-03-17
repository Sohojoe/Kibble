# ObjectiveBrowser

This is a sample app that demonstrates the use of Clang's C API discussed at [Messing about with Clang](http://blog.securemacprogramming.com/2012/05/messing-about-with-clang/)

The app itself is just a prototype I put together to learn how to use the API.

##Requirements

You need to build [clang](http://clang.llvm.org) and install it, so that you've got libClang and the interface headers.

##Limitations

 - The app isn't very useful at all. It browses the classes in a single hard-coded source file path, which is somewhere in my `Documents` folder. It then just shows the classes, methods and properties in an outline view with no attempt made to make sense of the beast.
 - The `FZAClassGroup` class isn't a good model; a real application might be interested in the contents of a project, or an executable, or a library. Or what [Brad Cox might call a category](http://blog.securemacprogramming.com/2012/04/software-ics-and-a-component-marketplace/).
 - The code is untested, except that I've seen it work. This was my one to throw away; enough people asked how it worked that I was willing to publish it but that doesn't mean you should start using it ;-).

## License
[WTFPL](http://sam.zoy.org/wtfpl/)
