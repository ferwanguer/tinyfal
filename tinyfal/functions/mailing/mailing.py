import requests
from jinja2 import Template

url = "https://api.forwardemail.net/v1/emails"
 # Username and empty password




# Define an HTML template
welcome_html_template = """
<!DOCTYPE html>
<html>
<head>
    <title>Bienvenido a Literatos</title>
</head>
<body>
    <div>
        <h1>Bienvenido a Literatos</h1>
        
        <p>Nuestra plataforma está diseñada para conectar a los amantes de la literatura con historias que inspiran, educan y entretienen.</p>
        <p>Explora nuestra colección de obras literarias, participa en debates apasionantes y comparte tus propias creaciones con una comunidad vibrante de lectores y escritores.</p>
        <p>Gracias por unirte a nosotros en este viaje. ¡Esperamos que disfrutes de la experiencia!</p>
        <div>
            <p>Si tienes alguna pregunta o necesitas ayuda, no dudes en contactarnos en <a href="mailto:app@literatos.net">app@literatos.net</a>.</p>
            <p>&copy; 2023 Literatos. Todos los derechos reservados.</p>
        </div>
    </div>
</body>
</html>
"""

# Define an HTML template for contest submission
contest_submission_html_template = """
<!DOCTYPE html>
<html>
<head>
    <title>Gracias por tu envío</title>
</head>
<body>
    <div>
        <h1>¡Gracias por participar en nuestro concurso literario!</h1>
        
        <p>Tu texto ha sido recibido con éxito y estamos emocionados de que formes parte de esta iniciativa.</p>
        <p>Te invitamos a registrarte en nuestra plataforma <a href="https://app.literatos.net">app.literatos.net</a> para explorar los textos enviados por otros participantes, interactuar con la comunidad y descubrir más oportunidades para compartir tu talento.</p>
        <p>Gracias por contribuir a enriquecer nuestra comunidad literaria.</p>
        <div>
            <p>Si tienes alguna pregunta o necesitas ayuda, no dudes en contactarnos en <a href="mailto:app@literatos.net">app@literatos.net</a>.</p>
            <p>&copy; 2023 Literatos. Todos los derechos reservados.</p>
        </div>
    </div>
</body>
</html>
"""

# Update the data dictionary to include the HTML content


# Create a Jinja2 template object
welcome_template = Template(welcome_html_template)

# Render the template with data
welcome_html_content = welcome_template.render()

# Create a Jinja2 template object for contest submission
contest_submission_template = Template(contest_submission_html_template)

# Render the template with data
contest_submission_html_content = contest_submission_template.render()

##########################################################################################
# Resource creation email template

resource_created_html_template = """
<!DOCTYPE html>
<html>
<head>
    <title>Nuevo recurso creado - Tinyfal</title>
</head>
<body>
    <div>
        <h1>¡Tu recurso ha sido creado exitosamente!</h1>
        
        <p>Hola,</p>
        <p>Te informamos que tu nuevo recurso <strong>"{{ resource_title }}"</strong> ha sido creado exitosamente en tu cuenta de Tinyfal.</p>
        <p>Ya puedes comenzar a enviar datos a este recurso utilizando el token que se generó para él.</p>
        
        <p>Puedes acceder a tu recurso y ver los datos en tiempo real desde tu panel de control en la aplicación.</p>
        
        <div>
            <p>Si tienes alguna pregunta o necesitas ayuda, no dudes en contactarnos en <a href="mailto:app@tinyfal.com">app@tinyfal.com</a>.</p>
            <p>&copy; 2025 Tinyfal. Todos los derechos reservados.</p>
        </div>
    </div>
</body>
</html>
"""

# Create a Jinja2 template object for resource creation
resource_created_template = Template(resource_created_html_template)

##########################################################################################
# Daily summary

daily_summary_html= """
    <html>
        <body>
            <h1>Resumen del día{{today}} </h1>
            <p><strong>Registros:</strong> {{new_users_count}}</p>
            <p><strong>Escritos creados:</strong> {{new_escritos_count}}</p>
        </body>
    </html>
    """
daily_summary_template = Template(daily_summary_html)

##########################################################################################
def mailto(to, subject, html_content, api_key):

    auth = (api_key, '') 
    # Send the email using the Forward Email API
    data = {
    'from': 'app@tinyfal.com',
    'to': to,
    'subject': subject,
    'html' : html_content,
    }
    response = requests.post(url, auth=auth, data=data)

    return response.status_code

def render_resource_created_email(resource_title):
    """Render the resource creation email template with the given resource title."""
    return resource_created_template.render(resource_title=resource_title)

if __name__ == "__main__":
    mailto("ferwanguer@me.com", "Bienvenido a Literatos", welcome_html_content)