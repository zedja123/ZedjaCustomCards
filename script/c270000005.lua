--
--Prismiant Flanirror
--scripted by Zedja
local s,id=GetID()
local SET_PRISMIANT=0xe00
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure: 1 Tuner + 1+ non-Tuner monsters
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	--If this card was Synchro Summoned using only "Prismiant" monsters as material, it is unaffected by other cards' effects, except the effects of "Prismiant" cards
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(function(e) return e:GetHandler():IsSynchroSummoned() and e:GetLabel()==1 end)
	e1:SetValue(s.immval)
	c:RegisterEffect(e1)
	--Check the materials used for its Synchro Summon
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_SINGLE)
	e1a:SetCode(EFFECT_MATERIAL_CHECK)
	e1a:SetValue(s.matcheck)
	e1a:SetLabelObject(e1)
	c:RegisterEffect(e1a)
	--During each End Phase: This card loses 500 ATK and 300 DEF
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_PRISMIANT}
function s.immval(e,te)
	return te:GetOwner()~=e:GetOwner() and not te:GetOwner():IsSetCard(SET_PRISMIANT)
end
function s.matcheck(e,c)
	local mg=c:GetMaterial()
	if #mg>0 and mg:FilterCount(Card.IsSetCard,nil,SET_PRISMIANT)==#mg then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsRelateToEffect(e) and c:IsFaceup()) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-500)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(-300)
	c:RegisterEffect(e2)
end
