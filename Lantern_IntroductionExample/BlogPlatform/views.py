from django.shortcuts import render
from django.http import HttpResponse
from os import listdir, path

# Create your views here.
def index(request):
    return render(request, 'BlogPlatform/home.html')

def about(request):
    return render(request, 'BlogPlatform/about.html')

def login(request):
    return render(request, 'BlogPlatform/login.html')

def articles(request):
    context = {'articles': [path.join('articles/previews/', f) #todo should be previews
                            for f in listdir('./templates/articles/previews')]}
    return render(request, 'BlogPlatform/articles.html', context)

def article(request, article):
    return render(request, 'articles/article.html', {'article', path.join('articles/articles/',
                                                                          str(article) + '.html')})
