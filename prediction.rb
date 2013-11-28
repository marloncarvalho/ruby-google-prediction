# encoding: UTF-8

require 'rubygems'
require 'google/api_client'

# Exemplo de uso da Prediction API do Google.
#
# Por Marlon Silva Carvalho
class Prediction
  DATA_OBJECT = 'preconceito-nordeste/preconceito-nordeste.csv'
  CLIENT_EMAIL = '639868454807-ahkp925e4sp5lc1mtomgh5inooejs6j4@developer.gserviceaccount.com'
  KEYFILE = 'certificado.p12'
  PASSPHRASE = 'notasecret'
  PROJECT_ID = '639868454807'

  # Fazendo a configuração para poder usar a Google API Client.
  #
  # Author Marlon Silva Carvalho
  def configure
    @client = Google::APIClient.new(
        :application_name => 'Ruby',
        :application_version => '1.0.0')

    key = Google::APIClient::PKCS12.load_key(KEYFILE, PASSPHRASE)
    asserter = Google::APIClient::JWTAsserter.new(CLIENT_EMAIL,'https://www.googleapis.com/auth/prediction',key)
    asserter.scope = ['https://www.googleapis.com/auth/devstorage.read_write','https://www.googleapis.com/auth/prediction']
    @client.authorization = asserter.authorize()

    @prediction = @client.discovered_api('prediction', 'v1.6')
  end

  # Fazer o treinamento da Prediction API.
  #
  # Author Marlon Silva Carvalho
  def train
    training = @prediction.trainedmodels.insert.request_schema.new
    training.id = 'preconceito-nordeste'
    training.storage_data_location = DATA_OBJECT
    result = @client.execute(
        :api_method => @prediction.trainedmodels.insert,
        :parameters => {'project' => PROJECT_ID},
        :headers => {'Content-Type' => 'application/json'},
        :body_object => training
    )

    puts result.inspect
  end

  # Checar o status do serviço.
  #
  # Author Marlon Silva Carvalho
  def check
    result = @client.execute(
        :api_method => @prediction.trainedmodels.get,
        :parameters => {'id' => 'preconceito-nordeste', 'project' => PROJECT_ID},
    )

    puts result.inspect
  end

  # Fazer uma predição.
  #
  # Author Marlon Silva Carvalho
  def predict(entrada)
    input = @prediction.trainedmodels.predict.request_schema.new
    input.input = {}
    input.input.csv_instance = [entrada]
    result = @client.execute(
        :api_method => @prediction.trainedmodels.predict,
        :parameters => {'id' => 'preconceito-nordeste', 'project' => PROJECT_ID},
        :headers => {'Content-Type' => 'application/json'},
        :body_object => input
    )

    result.data['outputMulti'].each do |a|
      puts a["label"]
      puts a["score"]
      puts "\n"
    end

  end

end

prediction = Prediction.new
prediction.configure
# prediction.train
# prediction.check
prediction.predict('Nordestino é um câncer!')