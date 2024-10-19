-- Milacresy Darkllunism Defense
local s,id=GetID()
function s.initial_effect(c)
	-- Negate and destroy
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,{id,1})
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)

	-- Set from banished
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_REMOVE)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetCountLimit(1,{id,2})
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end

function s.filter(c)
	return c:IsSetCard(0xf16) and c:IsFaceup()
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return (re:IsActiveType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP) or re:IsMonster()) and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil) -- Checks if you control a Milacresy monster
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(re:GetHandler(),REASON_EFFECT)
	end
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.SSet(tp,c)
end
