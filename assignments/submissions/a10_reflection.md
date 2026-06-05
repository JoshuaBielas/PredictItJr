I did some testing of the application with flutter run --profile and the release build. I noticed some parts weren't smooth. A couple of fixes i made were to add a const in portfolio screen, remove an uneccessary use of double quotes, and add a trailing comma.

# Part B Reflection

## Prompt 1
The prompt I have chosen to respond to is that "structure makes the next thing cheap." I have definitely found this to be true. In my internship this summer, a group of us interns worked on a practice project at the beginning of the summer. We did not plan it out enough. This led to issues later on as we were adding more features. We kept noticing things that would be way easier to implement if we had done the original design of the system correctly.

This application was built with this idea in mind. The decision I would like to trace through three assignments is the creation of MarketCard in assignment two. We created MarketCard within its own file. This led to easier changes in later assignments. In assignment five when we created wide and narrow views, we were able to use the same MarketCards. We just displayed them a little bit differently. In assignment 10 when we implemented widget testing, we could just check how many instances of the MarketCard class were on the screen and make sure it was the correct account. This is better than if we had just put the code for creating cards in the screen and not written it in a class. 

## Prompt 2

There were a few places where a seam we built made a later assignment easier. A specific example of where this happened was in PortfolioModel. We created PortfolioModel in the earlier assignments. When we created it we gave it an optional PortfolioStorage parameter. If it didn't receive one, it defaulted to using PortfolioStorage(). This wasn't useful until we started writing tests. Before writing tests, it always used PortfolioStorage. Having the optional parameter was very valuable when writing tests because it allowed us to pass a fake storage. This allows us to test that things are working correctly without affecting the actual storage.

A place where the structure could have been different was when we made MarketListScreen load markets internally. This made it so we couldn't pass any markets to it which made it difficult to test. I had to modify it to allow markets to be passed in. This allowed for easier testing.

## Prompt 3

The one non-Flutter idea from this course that I believe will outlast my knowledge is the idea that client-side plaintext auth is theater. Storing anything client-side and in plain text makes it insecure and easy to modify by the client. You don't want to allow authentication information to be easily visible in plain text because then people's information can be stolen pretty easily. Your goal as a developer should be to create secure apps that don't allow customers to be harmed by malicious individuals. Information like this should be encrypted if it is private and then stored in a server, so it can't be modified by anyone. 

This will outlast my knowledge because this is something that applies to writing any application with any framework. With all frameworks you need to think about privacy and how you will storing information in a way that doesn't allow modification. This isn't just a Flutter challenge. 

## Prompt 4

There are two places within this application where I would make different structural decisions if I were to restart with this application. I would include a database earlier on, so that bets and markets could be stored in an actual database. It wouldn't have to be a complex database, but it would be beneficial. A second place that I would make a structural change from the beginning of its implementation is giving AuthModel an optional parameter of an AuthStorage(). Thist makes it a lot easier and smoother to test. A final change that I would make that isn't really structural is doing test driven development. This would ensure that we know we are making our application do what we would like it to from the beginning.

A place that felt like overhead at the time but was a good design choice was creating the models first. These are the most important pieces because they determine how information will be stored and what is important for each piece. Starting with what we want our bets, markets, and users to look like allowed us to build the application around that shape. If we didn't do this, we might have ended up with some challenging or tedious fixes later in development when we decided we needed different information stored in each of those models.