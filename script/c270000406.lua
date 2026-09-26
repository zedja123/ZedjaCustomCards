--
--Build Driver - Love and Peace
--scripted by Zedja
local s,id=GetID()
local SET_BUILD_RIDER=0x1e04
function s.initial_effect(c)
	--Target 1 "Build Rider" Link Monster you control; apply the following effect(s) in sequence, based on its Attribute(s)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_RECOVER+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_BUILD_RIDER}
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(SET_BUILD_RIDER) and c:IsLinkMonster()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if tc:IsAttribute(ATTRIBUTE_WATER) then
		Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
	end
	if tc:IsAttribute(ATTRIBUTE_EARTH|ATTRIBUTE_WIND) then
		Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_ONFIELD)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end
	local applied=false
	local function step()
		if applied then Duel.BreakEffect() end
		applied=true
	end
	--FIRE: It gains 500 ATK until the end of this turn
	if tc:IsAttribute(ATTRIBUTE_FIRE) then
		step()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		tc:RegisterEffect(e1)
	end
	--WATER: Gain 1000 LP
	if tc:IsAttribute(ATTRIBUTE_WATER) then
		step()
		Duel.Recover(tp,1000,REASON_EFFECT)
	end
	--EARTH: Destroy 1 face-up card your opponent controls
	if tc:IsAttribute(ATTRIBUTE_EARTH) and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) then
		step()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,1,nil)
		Duel.HintSelection(g)
		Duel.Destroy(g,REASON_EFFECT)
	end
	--WIND: Destroy 1 face-down card your opponent controls
	if tc:IsAttribute(ATTRIBUTE_WIND) and Duel.IsExistingMatchingCard(Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,nil) then
		step()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,1,nil)
		Duel.HintSelection(g)
		Duel.Destroy(g,REASON_EFFECT)
	end
	if not (tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end
	--LIGHT: It can attack directly this turn
	if tc:IsAttribute(ATTRIBUTE_LIGHT) then
		step()
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(3205)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e2:SetCode(EFFECT_DIRECT_ATTACK)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		tc:RegisterEffect(e2)
	end
	--DARK: If it attacks a Defense Position monster this turn, it inflicts piercing battle damage
	if tc:IsAttribute(ATTRIBUTE_DARK) then
		step()
		local e3=Effect.CreateEffect(c)
		e3:SetDescription(3208)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e3:SetCode(EFFECT_PIERCE)
		e3:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		tc:RegisterEffect(e3)
	end
end
