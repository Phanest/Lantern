from django.urls import path
from django.conf import settings
from django.conf.urls.static import static
from . import views

urlpatterns = [
    path('', views.index, name='index'),
    path('about', views.about, name='about'),
    path('articles', views.articles, name='articles'),
    path('login', views.login, name='login'),
    path('articles/<int:article_id>', views.article, name='article'),
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)