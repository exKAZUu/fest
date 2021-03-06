require 'spec_helper'

describe Admin::QuestionsController do
  login_admin

  def valid_attributes
    attributes_for(:question)
  end

  describe "GET index" do
    it "assigns all questions as @questions" do
      question = Question.create! valid_attributes
      get :index, {}
      assigns(:questions).should eq([question])
    end
  end

  describe "GET show" do
    it "assigns the requested question as @question" do
      question = Question.create! valid_attributes
      get :show, {:id => question.to_param}
      assigns(:question).should eq(question)
    end
  end

  describe "GET edit" do
    it "assigns the requested question as @question" do
      question = Question.create! valid_attributes
      get :edit, {:id => question.to_param}
      assigns(:question).should eq(question)
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested question" do
        question = Question.create! valid_attributes
        # Assuming there are no other questions in the database, this
        # specifies that the Question created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Question.any_instance.should_receive(:update_attributes).with({ "email" => "MyString" })
        put :update, {:id => question.to_param, :question => { "email" => "MyString" }}
      end

      it "assigns the requested question as @question" do
        question = Question.create! valid_attributes
        put :update, {:id => question.to_param, :question => valid_attributes}
        assigns(:question).should eq(question)
      end

      it "redirects to the questions page" do
        question = Question.create! valid_attributes
        put :update, {:id => question.to_param, :question => valid_attributes}
        response.should redirect_to(admin_questions_url)
      end
    end

    describe "with invalid params" do
      it "assigns the question as @question" do
        question = Question.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Question.any_instance.stub(:save).and_return(false)
        Question.any_instance.stub(:errors).and_return(some: ['errors'])
        put :update, {:id => question.to_param, :question => { "email" => "" }}
        assigns(:question).should eq(question)
      end

      it "re-renders the 'edit' template" do
        question = Question.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Question.any_instance.stub(:save).and_return(false)
        Question.any_instance.stub(:errors).and_return(some: ['errors'])
        put :update, {:id => question.to_param, :question => { "email" => "" }}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested question" do
      question = Question.create! valid_attributes
      expect {
        delete :destroy, {:id => question.to_param}
      }.to change(Question, :count).by(-1)
    end

    it "redirects to the questions list" do
      question = Question.create! valid_attributes
      delete :destroy, {:id => question.to_param}
      response.should redirect_to(admin_questions_url)
    end
  end

end
